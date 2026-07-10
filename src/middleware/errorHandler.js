function notFound(req, res) {
  res.status(404).json({ message: `Route not found: ${req.method} ${req.originalUrl}` });
}

// eslint-disable-next-line no-unused-vars
function errorHandler(err, req, res, next) {
  console.error(err);

  // Prisma "record not found" style errors
  if (err.code === "P2025") {
    return res.status(404).json({ message: "Record not found" });
  }

  // Prisma unique constraint violation
  if (err.code === "P2002") {
    return res.status(409).json({
      message: "A record with that value already exists",
      fields: err.meta?.target
    });
  }

  // Prisma foreign key constraint failure (e.g. bad category_id/account_id)
  if (err.code === "P2003") {
    return res.status(400).json({ message: "Invalid reference: related record does not exist" });
  }

  res.status(err.status || 500).json({
    message: err.message || "Server error"
  });
}

module.exports = { notFound, errorHandler };
