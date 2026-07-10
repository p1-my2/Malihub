const express = require("express");
const router = express.Router();

const goalController = require("../controllers/goalController");
const { requireAuth } = require("../middleware/auth");

router.use(requireAuth);

router.get("/", goalController.getGoals);
router.post("/", goalController.createGoal);
router.put("/:id", goalController.updateGoal);
router.patch("/:id/contribute", goalController.contributeToGoal);
router.delete("/:id", goalController.deleteGoal);

module.exports = router;
