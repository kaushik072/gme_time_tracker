const express = require('express');
const pdfRoutes = require('./routes/pdf');

const app = express();

// Routes
app.use('/api', pdfRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
