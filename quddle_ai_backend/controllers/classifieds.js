const { supabase } = require('../config/database');
const { createPresignedPutUrl, s3Bucket, awsRegion } = require('../config/aws');
const { v4: uuidv4 } = require('uuid');
const { ADMIN_USER_ID } = require('./wallet');

// Loop Price: 1 LooP = ₹1 INR
const POSTING_FEE_LOOPS = 10; // 10 LooPs fee

// -------------------------------------------------------------
// POST CLASSIFIED
// -------------------------------------------------------------
const postClassified = async (req, res) => {
  try {
    const user = req.user;

    const { 
      title, 
      description, 
      price, 
      category, 
      location, 
      phone, 
      imageCount 
    } = req.body;

    // VALIDATION
    if (!title || !description) {
      return res.status(400).json({
        success: false,
        message: "Title and description are required"
      });
    }

    if (!phone || phone.trim().length < 10) {
      return res.status(400).json({
        success: false,
        message: "Valid phone number is required (minimum 10 digits)"
      });
    }

    // FETCH USER WALLET
    const { data: userWallet, error: walletError } = await supabase
      .from("wallets")
      .select("*")
      .eq("user_id", user.id)
      .single();

    if (walletError || !userWallet) {
      return res.status(400).json({
        success: false,
        message: "Wallet not found. Contact support."
      });
    }

    // CHECK BALANCE
    if (userWallet.balance < POSTING_FEE_LOOPS) {
      return res.status(400).json({
        success: false,
        message: `Insufficient balance. You need ${POSTING_FEE_LOOPS} LooPs to post an ad.`
      });
    }

    // FETCH ADMIN WALLET
    const { data: adminWallet } = await supabase
      .from("wallets")
      .select("*")
      .eq("user_id", ADMIN_USER_ID)
      .single();

    if (!adminWallet) {
      return res.status(500).json({
        success: false,
        message: "Admin wallet not found."
      });
    }

    // DEDUCT FROM USER
    const { error: deductError } = await supabase
      .from("wallets")
      .update({
        balance: userWallet.balance - POSTING_FEE_LOOPS,
        updated_at: new Date().toISOString()
      })
      .eq("id", userWallet.id);

    if (deductError) {
      return res.status(400).json({ success: false, message: deductError.message });
    }

    // CREDIT TO ADMIN
    const { error: creditError } = await supabase
      .from("wallets")
      .update({
        balance: adminWallet.balance + POSTING_FEE_LOOPS,
        updated_at: new Date().toISOString()
      })
      .eq("id", adminWallet.id);

    if (creditError) {
      await supabase
        .from("wallets")
        .update({ balance: userWallet.balance })
        .eq("id", userWallet.id);

      return res.status(400).json({ success: false, message: creditError.message });
    }

    // CREATE CLASSIFIED
    const classifiedId = uuidv4();

    const { data: classified, error: classifiedError } = await supabase
      .from("classifieds")
      .insert({
        id: classifiedId,
        user_id: user.id,
        title,
        description,
        price: price || null,
        category: category || null,
        location: location || null,
        phone: phone || null,
        posting_fee: POSTING_FEE_LOOPS,
        media_urls: [],
        media_types: []
      })
      .select()
      .single();

    if (classifiedError) {
      return res.status(400).json({ success: false, message: classifiedError.message });
    }

    // TRANSACTIONS
    await supabase.from("wallet_transactions").insert([
      {
        wallet_id: userWallet.id,
        amount: POSTING_FEE_LOOPS,
        type: "debit",
        description: `Posted classified: ${title}`,
        reference_type: "classified",
        reference_id: classifiedId
      },
      {
        wallet_id: adminWallet.id,
        amount: POSTING_FEE_LOOPS,
        type: "credit",
        description: `Posting fee from user: ${title}`,
        reference_type: "classified",
        reference_id: classifiedId
      }
    ]);

    // UPLOAD URLS
    const uploadUrls = [];
    if (imageCount && imageCount > 0) {
      for (let i = 0; i < Math.min(imageCount, 10); i++) {
        const fileKey = `classifieds/${user.id}/${classifiedId}/media_${i}`;

        const uploadUrl = await createPresignedPutUrl({
          key: fileKey,
          contentType: "image/jpeg",
          expiresInSeconds: 900
        });

        uploadUrls.push({ key: fileKey, uploadUrl });
      }
    }

    return res.status(201).json({
      success: true,
      classified,
      uploadUrls,
      message: `Ad posted successfully! ${POSTING_FEE_LOOPS} LooPs deducted.`,
      newBalance: userWallet.balance - POSTING_FEE_LOOPS
    });

  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

// -------------------------------------------------------------
// GET ALL CLASSIFIEDS
// -------------------------------------------------------------
const getClassifieds = async (req, res) => {
  try {
    const { category, status = "active" } = req.query;

    let query = supabase
      .from("classifieds")
      .select("*")
      .eq("status", status)
      .order("created_at", { ascending: false });

    if (category) {
      query = query.eq("category", category);
    }

    const { data: classifieds, error } = await query;

    if (error) {
      return res.status(400).json({ success: false, message: error.message });
    }

    return res.status(200).json({ success: true, classifieds });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

// -------------------------------------------------------------
// GET USER'S OWN CLASSIFIEDS
// -------------------------------------------------------------
const getMyClassifieds = async (req, res) => {
  try {
    const user = req.user;

    const { data: classifieds, error } = await supabase
      .from("classifieds")
      .select("*")
      .eq("user_id", user.id)
      .order("created_at", { ascending: false });

    if (error) {
      return res.status(400).json({ success: false, message: error.message });
    }

    return res.status(200).json({ success: true, classifieds });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

// -------------------------------------------------------------
// UPDATE MEDIA
// -------------------------------------------------------------
const updateClassifiedImages = async (req, res) => {
  try {
    const user = req.user;
    const { id } = req.params;
    const { imageKeys, mediaTypes } = req.body;

    const { data: classified, error: fetchError } = await supabase
      .from("classifieds")
      .select("*")
      .eq("id", id)
      .eq("user_id", user.id)
      .single();

    if (fetchError || !classified) {
      return res.status(404).json({
        success: false,
        message: "Classified not found"
      });
    }

    const mediaUrls = imageKeys.map(key =>
      `https://${s3Bucket}.s3.${awsRegion}.amazonaws.com/${key}`
    );

    const { error: updateError } = await supabase
      .from("classifieds")
      .update({
        media_urls: mediaUrls,
        media_types: mediaTypes || []
      })
      .eq("id", id);

    if (updateError) {
      return res.status(400).json({ success: false, message: updateError.message });
    }

    return res.status(200).json({
      success: true,
      message: "Media updated successfully"
    });

  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
};

// -------------------------------------------------------------
// EXPORTS
// -------------------------------------------------------------
module.exports = {
  postClassified,
  getClassifieds,
  getMyClassifieds,
  updateClassifiedImages
};
