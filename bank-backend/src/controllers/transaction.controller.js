const pool = require("../config/db");
exports.getTransactions = async (req, res) => {
  try {
    
    const userId = req.user.id;
    

    const [[user]] = await pool.query(
      "SELECT accountNo FROM users WHERE id = ?",
      [userId]
    );

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const [transactions] = await pool.query(
      `
      SELECT 
        id,
        from_account,
        to_account,
        amount,
        description,
        type,
        created_at
      FROM transactions
      WHERE from_account = ? OR to_account = ?
      ORDER BY created_at DESC
      LIMIT 20
      `,
      [user.accountNo, user.accountNo]
    );

    res.json(transactions);
  } catch (e) {
    res.status(500).json({ message: "Server error" });
  }
};
