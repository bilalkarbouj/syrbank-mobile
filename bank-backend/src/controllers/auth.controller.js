const pool = require("../config/db");
const bcrypt = require("bcrypt");
const { generateToken } = require("../config/jwt");



function generateAccountNo() {
  let accountNo = '';
  for (let i = 0; i < 16; i++) {
    accountNo += Math.floor(Math.random() * 10);
  }
  return accountNo;
}


exports.register = async (req, res) => {
  const { fullName, firstName, lastName, email, password } = req.body;

  let accountNo = generateAccountNo();

  while (await userExistsByAccountNo(accountNo)) {
    accountNo = generateAccountNo();
  }

  const [exists] = await pool.query(
    "SELECT id FROM users WHERE email = ?",
    [email]
  );

  if (exists.length > 0) {
    return res.status(400).json({ message: "Email already exists" });
  }

  const hashedPassword = await bcrypt.hash(password, 10);

  await pool.query(
    "INSERT INTO users (full_name, first_name, last_name, email, password, accountNo) VALUES (?, ?, ?, ?, ?, ?)",
    [fullName, firstName, lastName, email, hashedPassword, accountNo]
  );

  res.status(201).json({ message: "User registered successfully" });
};

async function userExistsByAccountNo(accountNo) {
  const [rows] = await pool.query(
    "SELECT id FROM users WHERE accountNo = ?",
    [accountNo]
  );
  return rows.length > 0;
}


exports.login = async (req, res) => {
  const { email, password } = req.body;

  const [users] = await pool.query(
    "SELECT * FROM users WHERE email = ?",
    [email]
  );

  if (users.length === 0) {
    return res.status(401).json({ message: "Invalid credentials" });
  }

  const user = users[0];
  const isMatch = await bcrypt.compare(password, user.password);

  if (!isMatch) {
    return res.status(401).json({ message: "Invalid credentials1" });
  }

  const token = generateToken({
    id: user.id,
    email: user.email,
  });

  res.json({
    accessToken: token,
    user: {
      id: user.id,
      fullName: user.full_name,
      first_name: user.first_name,
      last_name: user.last_name,
      balance: user.balance,
    },
  });
};

// authController.js
exports.me = async (req, res) => {
  try {
    console.log('req.user:', req.user);
    const userId = req.user.id; // <-- düzeltildi

    const [rows] = await pool.query(
      "SELECT id, full_name, first_name, last_name, email, phone, accountNo, balance FROM users WHERE id = ?",
      [userId]
    );


    const user = rows[0];

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json({
      id: user.id,
      fullname: user.full_name,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      phone: user.phone, // ✅ EKLENDİ
      accountNo: user.accountNo,
      balance: user.balance,
    });


  } catch (e) {
    res.status(500).json({ message: "Server error" });
  }
};


 exports.changePassword = async (req, res) => {
  const { oldPassword, newPassword } = req.body;

  if (!oldPassword || !newPassword) {
    return res.status(400).json({ message: 'Both old and new passwords are required' });
  }

  try {
    // Kullanıcıyı veritabanından al
    const [rows] = await pool.execute(
      'SELECT password FROM users WHERE id = ?',
      [req.user.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ message: 'User not found' });
    }

    const user = rows[0];

    // Eski şifre kontrolü
    const match = await bcrypt.compare(oldPassword, user.password);
    if (!match) {
      return res.status(401).json({ message: 'Old password is incorrect' });
    }

    // Yeni şifreyi hashle
    const hashedPassword = await bcrypt.hash(newPassword, 10);

    // Veritabanını güncelle
    await pool.execute('UPDATE users SET password = ? WHERE id = ?', [
      hashedPassword,
      req.user.id,
    ]);
    console.log('Password updated for user ID:', req.user.email);

    res.json({ message: 'Password changed successfully' });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};