const { supabase } = require('../config/database');

const POSTING_FEE = 50; // AED
const ADMIN_USER_ID = '34f2bf42-0481-46cc-9e81-33284d4f8fe3';
const DOLLAR_TO_AED_RATE = 3.67; // 1 USD = 3.67 AED

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
      // Create wallet if doesn't exist with initial 1000 AED (mock money)
      const { data: newWallet, error: createError } = await supabase
        .from('wallets')
        .insert({ user_id: user.id, balance: 1000.00, currency: 'AED' })
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
    const { dollars } = req.body;

    // Validate input
    if (!dollars || isNaN(dollars) || dollars <= 0) {
      return res.status(400).json({ 
        success: false, 
        message: 'Please enter a valid amount' 
      });
    }

    // Convert dollars to AED
    const aedAmount = parseFloat((dollars * DOLLAR_TO_AED_RATE).toFixed(2));
    console.log(`Converting $${dollars} to AED ${aedAmount}`);

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
    const newBalance = parseFloat(wallet.balance) + aedAmount;
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
        amount: aedAmount,
        type: 'credit',
        description: `Added $${dollars} (AED ${aedAmount})`,
        reference_type: 'top_up',
      });

    if (transactionError) {
      console.error('Transaction record error:', transactionError);
    }

    console.log('Money added successfully');
    return res.status(200).json({ 
      success: true, 
      message: `Successfully added AED ${aedAmount} to your wallet`,
      newBalance,
      dollarsAdded: dollars,
      aedAdded: aedAmount
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
      rate: DOLLAR_TO_AED_RATE,
      currency: 'AED'
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