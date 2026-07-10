const jwt = require("jsonwebtoken");

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || "7d";

if (!JWT_SECRET) {
  // Fail loudly at startup rather than silently signing insecure tokens.
  throw new Error(
    "JWT_SECRET is not set. Add it to your .env file (see .env.example)."
  );
}

function signToken(user) {
  return jwt.sign(
    { user_id: user.user_id, email: user.email },
    JWT_SECRET,
    { expiresIn: JWT_EXPIRES_IN }
  );
}

function verifyToken(token) {
  return jwt.verify(token, JWT_SECRET);
}

module.exports = { signToken, verifyToken };
