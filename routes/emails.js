const express = require('express');
const router = express.Router();
router.get('/', (req, res) => {
  res.json({ message: 'Emails route working' });
});
module.exports = router;
