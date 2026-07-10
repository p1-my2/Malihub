const bcrypt = require("bcrypt");
const prisma = require("../config/prisma");

// GET /api/users/me
exports.getMe = async (req, res, next) => {
  try {
    const user = await prisma.users.findUnique({
      where: { user_id: req.user.user_id }
    });

    if (!user) return res.status(404).json({ message: "User not found" });

    const { password_hash, ...safeUser } = user;
    res.json(safeUser);
  } catch (error) {
    next(error);
  }
};

// PUT /api/users/me
exports.updateMe = async (req, res, next) => {
  try {
    const { first_name, last_name, phone_number, currency_preference } = req.body;

    const updated = await prisma.users.update({
      where: { user_id: req.user.user_id },
      data: { first_name, last_name, phone_number, currency_preference }
    });

    const { password_hash, ...safeUser } = updated;
    res.json(safeUser);
  } catch (error) {
    next(error);
  }
};

// PUT /api/users/me/password
exports.changePassword = async (req, res, next) => {
  try {
    const { current_password, new_password } = req.body;

    if (!current_password || !new_password) {
      return res.status(400).json({
        message: "current_password and new_password are required"
      });
    }

    const user = await prisma.users.findUnique({
      where: { user_id: req.user.user_id }
    });

    const matches = await bcrypt.compare(current_password, user.password_hash);
    if (!matches) {
      return res.status(401).json({ message: "Current password is incorrect" });
    }

    const password_hash = await bcrypt.hash(new_password, 10);

    await prisma.users.update({
      where: { user_id: req.user.user_id },
      data: { password_hash }
    });

    res.json({ message: "Password updated successfully" });
  } catch (error) {
    next(error);
  }
};
