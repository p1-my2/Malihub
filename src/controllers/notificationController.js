const prisma = require("../config/prisma");

// GET /api/notifications
exports.getNotifications = async (req, res, next) => {
  try {
    const notifications = await prisma.notifications.findMany({
      where: { user_id: req.user.user_id },
      orderBy: { created_at: "desc" }
    });
    res.json(notifications);
  } catch (error) {
    next(error);
  }
};

// PATCH /api/notifications/:id/read
exports.markAsRead = async (req, res, next) => {
  try {
    const notificationId = Number(req.params.id);

    const existing = await prisma.notifications.findFirst({
      where: { notification_id: notificationId, user_id: req.user.user_id }
    });
    if (!existing) return res.status(404).json({ message: "Notification not found" });

    const updated = await prisma.notifications.update({
      where: { notification_id: notificationId },
      data: { is_read: true }
    });

    res.json(updated);
  } catch (error) {
    next(error);
  }
};

// PATCH /api/notifications/read-all
exports.markAllAsRead = async (req, res, next) => {
  try {
    await prisma.notifications.updateMany({
      where: { user_id: req.user.user_id, is_read: false },
      data: { is_read: true }
    });
    res.json({ message: "All notifications marked as read" });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/notifications/:id
exports.deleteNotification = async (req, res, next) => {
  try {
    const notificationId = Number(req.params.id);

    const existing = await prisma.notifications.findFirst({
      where: { notification_id: notificationId, user_id: req.user.user_id }
    });
    if (!existing) return res.status(404).json({ message: "Notification not found" });

    await prisma.notifications.delete({ where: { notification_id: notificationId } });
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
