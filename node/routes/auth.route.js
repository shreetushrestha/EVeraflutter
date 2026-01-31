import { Router } from "express";
import { logIn, logOut, signUp,   forgotPassword, resetPassword } from "../controllers/auth.controller.js";
const authRouter = Router();

authRouter.post('/signup', signUp);
authRouter.post('/log-in', logIn);
authRouter.post('/log-out', logOut);
authRouter.post('/forgot-password', forgotPassword);
authRouter.post('/reset-password/:token', resetPassword);

export default authRouter;