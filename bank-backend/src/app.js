require("dotenv").config();
const express = require("express");
const cors = require("cors");


const authRoutes = require("./routes/auth.routes");
const userRoutes = require("./routes/user.routes");
const transactionRoutes = require("./routes/transaction.routes");
const transferRoutes = require("./routes/transfer.routes");


const app = express();
app.use(cors());
app.use(express.json());

app.use("/auth", authRoutes);
app.use("/user", userRoutes);
app.use("/transfer", transferRoutes);
app.use("/transactions", transactionRoutes);








module.exports = app;


