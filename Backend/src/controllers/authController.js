const bcrypt = require("bcrypt");
const prisma = require("../config/prisma");
const { signToken } = require("../utils/jwt");

const DEFAULT_CATEGORIES = [
  { category_name: "Food & Dining", icon: "restaurant" },
  { category_name: "Transport", icon: "directions_car" },
  { category_name: "Bills & Utilities", icon: "receipt_long" },
  { category_name: "Shopping", icon: "shopping_bag" },
  { category_name: "Salary", icon: "payments" }
];

exports.register = async (req, res, next) => {
  try {
    const { first_name, last_name, email, phone_number, password } = req.body;

    if (!first_name || !last_name || !email || !password) {
      return res.status(400).json({
        message: "first_name, last_name, email and password are required"
      });
    }

    const existingUser = await prisma.users.findUnique({ where: { email } });

    if (existingUser) {
      return res.status(400).json({ message: "Email already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    // Create the user and seed default categories together so a brand-new
    // account has something to pick from on the transaction/budget screens.
    const user = await prisma.$transaction(async (tx) => {
      const created = await tx.users.create({
        data: {
          first_name,
          last_name,
          email,
          phone_number,
          password_hash: hashedPassword
        }
      });

      await tx.categories.createMany({
        data: DEFAULT_CATEGORIES.map((c) => ({
          user_id: created.user_id,
          category_name: c.category_name,
          icon: c.icon,
          is_default: true
        }))
      });

      return created;
    });

    const token = signToken(user);
    const { password_hash, ...safeUser } = user;

    res.status(201).json({
      message: "User registered successfully",
      token,
      user: safeUser
    });
  } catch (error) {
    next(error);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: "email and password are required" });
    }

    const user = await prisma.users.findUnique({ where: { email } });

    if (!user || !user.is_active) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    const passwordMatches = await bcrypt.compare(password, user.password_hash);

    if (!passwordMatches) {
      return res.status(401).json({ message: "Invalid email or password" });
    }

    await prisma.users.update({
      where: { user_id: user.user_id },
      data: { last_login_at: new Date() }
    });

    const token = signToken(user);
    const { password_hash, ...safeUser } = user;

    res.status(200).json({
      message: "Login successful",
      token,
      user: safeUser
    });
  } catch (error) {
    next(error);
  }
};
