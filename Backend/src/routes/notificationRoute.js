const express = require("express");
const router = express.Router();

const notificationController = require("../controllers/notificationController");
const { requireAuth } = require("../middleware/auth");

router.use(requireAuth);

router.get("/", notificationController.getNotifications);
router.patch("/read-all", notificationController.markAllAsRead);
router.patch("/:id/read", notificationController.markAsRead);
router.delete("/:id", notificationController.deleteNotification);

module.exports = router;
