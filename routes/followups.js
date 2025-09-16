const express = require('express');
const router = express.Router();
router.get('/', (req, res) => {
  res.json({ message: 'Follow-Ups route working' });
});
module.exports = router;
