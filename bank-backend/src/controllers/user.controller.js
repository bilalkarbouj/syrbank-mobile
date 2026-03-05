const pool = require("../config/db");

exports.me = async (req, res) => {
  const userId = req.user.id;

  const [rows] = await pool.query(
    "SELECT id, full_name, last_name, first_name, email, balance FROM users WHERE id = ?",
    [userId]
  );

  if (rows.length === 0) {
    return res.status(404).json({ message: "User not found" });
  }
  console.log(rows[0]);
  res.json(rows[0]);
};


exports.updateProfile = async (req, res) => {
  const userId = req.user.id;
  const {first_name, last_name, phone } = req.body; 
  const full_name = `${first_name} ${last_name}`;

  const [rows] = await pool.query(
    "UPDATE users SET full_name=?, first_name = ?, last_name = ?, phone = ? WHERE id = ?",
    [full_name, first_name, last_name, phone, userId]
  );

  if (rows.affectedRows === 0) {
    return res.status(404).json({ message: "User not found" });
  }

  res.json({ message: "Profile updated successfully" });
};