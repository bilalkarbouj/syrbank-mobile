const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/auth.middleware");
const controller = require("../controllers/transaction.controller");

router.get("/", authMiddleware, controller.getTransactions);
module.exports = router;
