const express = require("express");
const router = express.Router();
const authMiddleware = require("../middleware/auth.middleware");
const userController = require("../controllers/user.controller");

router.get("/me", authMiddleware, userController.me);
router.post("/updateprofile", authMiddleware, userController.updateProfile);

module.exports = router;
