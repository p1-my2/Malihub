const express = require("express");
const cors = require("cors");

const authRoutes = require("./routes/authRoute");
const userRoutes = require("./routes/userRoute");
const accountRoutes = require("./routes/accountRoute");
const categoryRoutes = require("./routes/categoryRoute");
const transactionRoutes = require("./routes/transactionRoute");
const budgetRoutes = require("./routes/budgetRoute");
const goalRoutes = require("./routes/goalRoute");
const notificationRoutes = require("./routes/notificationRoute");

const { notFound, errorHandler } = require("./middleware/errorHandler");

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
  res.send("Malihub Backend is running");
});

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/accounts", accountRoutes);
app.use("/api/categories", categoryRoutes);
app.use("/api/transactions", transactionRoutes);
app.use("/api/budgets", budgetRoutes);
app.use("/api/goals", goalRoutes);
app.use("/api/notifications", notificationRoutes);

app.use(notFound);
app.use(errorHandler);

module.exports = app;
