import { Router } from "express";
import { logIn, logOut, signUp } from "../controllers/auth.controller.js";
const authRouter = Router();

authRouter.post('/signup', signUp);
authRouter.post('/log-in', logIn);
authRouter.post('/log-out', logOut);

export default authRouter;