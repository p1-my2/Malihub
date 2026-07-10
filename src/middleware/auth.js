const { verifyToken } = require("../utils/jwt");

/**
 * Protects a route: requires a valid `Authorization: Bearer <token>` header.
 * On success, attaches the decoded payload to req.user (contains user_id, email).
 */
function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ message: "No token provided" });
  }

  const token = authHeader.split(" ")[1];

  try {
    const decoded = verifyToken(token);
    req.user = decoded; // { user_id, email, iat, exp }
    next();
  } catch (error) {
    return res.status(401).json({ message: "Invalid or expired token" });
  }
}

module.exports = { requireAuth };
