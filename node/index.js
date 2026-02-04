import express from 'express';
import cors from 'cors';

import authRouter from './routes/auth.route.js';
import userRouter from './routes/user.route.js';
import stationRouter from './routes/station.route.js';

import { PORT } from './config/env.js';
import connectToDatabase from './database/mongodb.js';
import errorMiddleware from './middlewares/error.middleware.js';
import bookingRouter from './routes/bookings.route.js';

const app = express();

app.use(cors({
  origin: true,
  credentials: true,
}));


/* =======================
   BODY PARSERS
   ======================= */
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

/* =======================
   ROUTES
   ======================= */
app.use('/api/v1/auth', authRouter);
app.use('/api/v1/users', userRouter);
app.use('/api/v1/stations', stationRouter);
app.use('/api/v1/bookings', bookingRouter);

/* =======================
   ERROR HANDLER
   ======================= */
app.use(errorMiddleware);

/* =======================
   TEST ROUTE
   ======================= */
app.get('/', (req, res) => {
  res.send('hello world');
});

/* =======================
   SERVER START
   ======================= */
const startServer = async () => {
  try {
    await connectToDatabase();
    console.log('MongoDB connected');

    app.listen(PORT, () => {
      console.log(`Server running on http://localhost:${PORT}`);
    });

  } catch (err) {
    console.error('Startup error:', err);
    process.exit(1);
  }
};

startServer();

export default app;
