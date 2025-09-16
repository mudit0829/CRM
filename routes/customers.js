const express = require('express');
const router = express.Router();

// Sample route to test
router.get('/', (req, res) => {
  res.json({ message: 'Customers route is working' });
});

module.exports = router;
