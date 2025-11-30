const { supabase } = require('../config/database');

const POSTING_FEE = 10; // LooP
const ADMIN_USER_ID = '34f2bf42-0481-46cc-9e81-33284d4f8fe3';
const RUPEE_TO_LOOP_RATE = 1; // 1 INR = 1 LooP

// Get user wallet
const getWallet = async (req, res) => {
  try {
    const user = req.user;

    let { data: wallet, error } = await supabase
      .from('wallets')
      .select('*')
      .eq('user_id', user.id)
      .single();

    if (error && error.code === 'PGRST116') {
      // Create wallet if doesn't exist with initial 1000 LooP (mock money)
      const { data: newWallet, error: createError } = await supabase
        .from('wallets')
        .insert({ user_id: user.id, balance: 1000.00, currency: 'LooP' })
        .select()
        .single();

      if (createError) {
        return res.status(400).json({ success: false, message: createError.message });
      }
      wallet = newWallet;
    } else if (error) {
      return res.status(400).json({ success: false, message: error.message });
    }

    return res.status(200).json({ success: true, wallet });
  } catch (error) {
    console.error('Error in getWallet:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// Get wallet transactions
const getTransactions = async (req, res) => {
  try {
    const user = req.user;

    const { data: wallet } = await supabase
      .from('wallets')
      .select('id')
      .eq('user_id', user.id)
      .single();

    if (!wallet) {
      return res.status(404).json({ success: false, message: 'Wallet not found' });
    }

    const { data: transactions, error } = await supabase
      .from('wallet_transactions')
      .select('*')
      .eq('wallet_id', wallet.id)
      .order('created_at', { ascending: false });

    if (error) {
      return res.status(400).json({ success: false, message: error.message });
    }

    return res.status(200).json({ success: true, transactions });
  } catch (error) {
    console.error('Error in getTransactions:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// Add money to wallet (mock payment - replace with Stripe later)
const addMoney = async (req, res) => {
  try {
    console.log('Add money request received:', req.body);
    const user = req.user;
    const { rupees } = req.body;  // CHANGED: from 'dollars' to 'rupees'

    // Validate input
    if (!rupees || isNaN(rupees) || rupees <= 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'Please enter a valid amount' 
      });
    }

    // Convert rupees to LooP (1:1 ratio)
    const loopAmount = parseFloat((rupees * RUPEE_TO_LOOP_RATE).toFixed(2));
    console.log(`Converting ₹${rupees} to LooP ${loopAmount}`);

    // Get user wallet
    const { data: wallet, error: walletError } = await supabase
      .from('wallets')
      .select('*')
      .eq('user_id', user.id)
      .single();

    if (walletError || !wallet) {
      console.error('Wallet error:', walletError);
      return res.status(400).json({ 
        success: false, 
        message: 'Wallet not found. Please contact support.' 
      });
    }

    console.log('Current wallet balance:', wallet.balance);

    // Update wallet balance
    const newBalance = parseFloat(wallet.balance) + loopAmount;
    console.log('New balance will be:', newBalance);

    const { error: updateError } = await supabase
      .from('wallets')
      .update({ 
        balance: newBalance,
        updated_at: new Date().toISOString()
      })
      .eq('id', wallet.id);

    if (updateError) {
      console.error('Update error:', updateError);
      return res.status(400).json({ success: false, message: updateError.message });
    }

    // Record transaction
    const { error: transactionError } = await supabase
      .from('wallet_transactions')
      .insert({
        wallet_id: wallet.id,
        amount: loopAmount,
        type: 'credit',
        description: `Added ₹${rupees} (LooP ${loopAmount})`,
        reference_type: 'top_up',
      });

    if (transactionError) {
      console.error('Transaction record error:', transactionError);
    }

    console.log('Money added successfully');
    return res.status(200).json({ 
      success: true, 
      message: `Successfully added LooP ${loopAmount} to your wallet`,
      newBalance,
      rupeesAdded: rupees,
      loopAdded: loopAmount
    });
  } catch (error) {
    console.error('Error in addMoney:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

// Get exchange rate
const getExchangeRate = async (req, res) => {
  try {
    return res.status(200).json({ 
      success: true, 
      rate: RUPEE_TO_LOOP_RATE,
      currency: 'LooP',
      baseCurrency: 'INR'
    });
  } catch (error) {
    console.error('Error in getExchangeRate:', error);
    return res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  getWallet,
  getTransactions,
  addMoney,
  getExchangeRate,
  POSTING_FEE,
  ADMIN_USER_ID
};