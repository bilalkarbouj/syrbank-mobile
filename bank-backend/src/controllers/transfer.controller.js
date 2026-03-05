const pool = require("../config/db");
const { getIO } = require("../socket");
exports.transfer = async (req, res) => {
  const { toAccountNo, amount, description } = req.body;
  const userId = req.user.id;

  const io = getIO(); // ✅ BURADA

  if (!toAccountNo || !amount || amount <= 0) {
    return res.status(400).json({ message: "Invalid transfer data" });
  }
  const rawAmount = Number(req.body.amount);

  if (!rawAmount || rawAmount <= 0) {
    return res.status(400).json({ message: "Invalid amount" });
  }

  const maxAmount = req.body.maxAmount;

  if (maxAmount && rawAmount > maxAmount) {
    return res.status(400).json({
      message: "QR max tutar limiti aşıldı"
    });
  }



  const cleantoAccountNo = toAccountNo.replace(/\s+/g, '');


  const connection = await pool.getConnection();

  try {
    await connection.beginTransaction();

    const [[sender]] = await connection.query(
      "SELECT accountNo, balance, full_name FROM users WHERE id = ? FOR UPDATE",
      [userId]
    );

    if (!sender || sender.balance < rawAmount) {
      throw new Error("Insufficient balance");
    }


    const [[receiver]] = await connection.query(
      "SELECT accountNo FROM users WHERE accountNo = ? FOR UPDATE",
      [cleantoAccountNo]
    );


    if (!receiver) {
      throw new Error("Receiver not found");
    }

    await connection.query(
      "UPDATE users SET balance = balance - ? WHERE id = ?",
      [rawAmount, userId]
    );

    await connection.query(
      "UPDATE users SET balance = balance + ? WHERE accountNo = ?",
      [rawAmount, cleantoAccountNo]
    );

    await connection.query(
      `INSERT INTO transactions 
       (from_account, to_account, amount, description, type)
       VALUES (?, ?, ?, ?, 'transfer')`,
      [
        sender.accountNo,
        cleantoAccountNo,
        rawAmount,
        description || "-",
      ]
    );


    await connection.commit();



    // 🔁 GÜNCEL BAKİYELERİ ÇEK
    const [[updatedSender]] = await pool.query(
      "SELECT balance FROM users WHERE id = ?",
      [userId]
    );

    const [[updatedReceiver]] = await pool.query(
      "SELECT balance FROM users WHERE accountNo = ?",
      [cleantoAccountNo]
    );

    // 🟢 GÖNDERENİN BALANCE'I
    io.to(sender.accountNo).emit("balance:update", {
      balance: updatedSender.balance,
    });

    // 🟢 ALICININ BALANCE'I
    io.to(cleantoAccountNo).emit("balance:update", {
      balance: updatedReceiver.balance,
    });


    io.to(cleantoAccountNo).emit("notification", {
      type: "TRANSFER_RECEIVED",
      amount: rawAmount,
      name: sender.full_name,
      from: sender.accountNo,
    });


    res.json({ message: "Transfer successful" });
  } catch (err) {
    await connection.rollback();
    res.status(400).json({ message: err.message });
  } finally {
    connection.release();
  }
};


exports.checkAccount = async (req, res) => {

  const { accountNo } = req.params;


  const [[user]] = await pool.query(
    "SELECT id FROM users WHERE accountNo = ?",
    [accountNo]
  );

  if (!user) {
    return res.status(404).json({ exists: false });
  }

  res.json({ exists: true });
}




