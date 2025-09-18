const express = require('express');
const Customer = require('../models/customer');
const authMiddleware = require('../middleware/auth');
const router = express.Router();

router.use(authMiddleware);

router.get('/', async (req, res) => {
  try {
    const customers = await Customer.findAll({ where: { createdBy: req.user.id } });
    res.json(customers);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

router.post('/', async (req, res) => {
  const { name, email, phone, address } = req.body;
  try {
    const customer = await Customer.create({ name, email, phone, address, createdBy: req.user.id });
    res.json(customer);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

router.put('/:id', async (req, res) => {
  const { id } = req.params;
  const { name, email, phone, address } = req.body;
  try {
    const customer = await Customer.findOne({ where: { id, createdBy: req.user.id } });
    if (!customer) return res.status(404).json({ message: 'Customer not found' });

    await customer.update({ name, email, phone, address });
    res.json(customer);
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

router.delete('/:id', async (req, res) => {
  const { id } = req.params;
  try {
    const customer = await Customer.findOne({ where: { id, createdBy: req.user.id } });
    if (!customer) return res.status(404).json({ message: 'Customer not found' });

    await customer.destroy();
    res.json({ message: 'Customer deleted' });
  } catch (error) {
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
