const express = require('express');
const router = express.Router();
router.get('/', (req, res) => {
  res.json({ message: 'Deals route working' });
});
module.exports = router;
