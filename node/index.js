import express from 'express';
import authRouter from './routes/auth.route.js';
import { PORT } from './config/env.js';
import connectToDatabase from './database/mongodb.js';
import userRouter from './routes/user.route.js';
import errorMiddleware from './middlewares/error.middleware.js';

const app = express();

app.use(express.json());
app.use(express.urlencoded({extended: false}))


app.use('/api/v1/auth', authRouter)
app.use('/api/v1/users', userRouter)



app.use(errorMiddleware);


app.get('/', (req, res)=>{
    res.send('hello world');
});
app.get('/hlo', (req, res) => {
    res.send("Hello from the server!");
});
const startServer = async () => {
    try {
        await connectToDatabase(); // ⬅ MUST BE HERE
        console.log("MongoDB connected");

        app.listen(PORT, () => {
            console.log(`Server running on http://localhost:${PORT}`);
        });

    } catch (err) {
        console.error("Startup error:", err);
        process.exit(1);
    }
};

startServer();



export default app; 