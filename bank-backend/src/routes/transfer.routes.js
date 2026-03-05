const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/auth.middleware");
const transfer = require("../controllers/transfer.controller");

router.post("/", authMiddleware, transfer.transfer);

router.get("/check-account/:accountNo", authMiddleware,transfer.checkAccount );


module.exports = router;
