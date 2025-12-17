import mongoose from "mongoose";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import User from "../models/user.models.js";
import { JWT_SECRET, JWT_EXPIRES_IN } from "../config/env.js";

export const signUp = async (req, res, next) => {
    const session = await mongoose.startSession();
    session.startTransaction();

    try {
        const { name, email, phone, password } = req.body;

        if (!name || !email || !phone || !password) {
            throw new Error("All fields are required");
        }

        if (!/^\d{10}$/.test(phone)) {
            throw new Error("Phone number must be exactly 10 digits");
        }

        const existingUser = await User.findOne({ email });
        if (existingUser) throw new Error("User already exists");

        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const newUser = await User.create(
            [{ name, email, phone, password: hashedPassword }],
            { session }
        );

        const token = jwt.sign(
            { userId: newUser[0]._id },
            JWT_SECRET,
            { expiresIn: JWT_EXPIRES_IN }
        );

        await session.commitTransaction();
        session.endSession();

        res.status(201).json({
            success: true,
            message: "User created successfully",
            data: {
                token,
                user: newUser[0],
            },
        });

    } catch (error) {
        await session.abortTransaction();
        session.endSession();
        next(error);
    }
};


export const logIn = async (req, res, next) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            const err = new Error('Email and password are required');
            err.status = 400;
            throw err;
        }

        const user = await User.findOne({ email }).exec();
        if (!user) {
            const err = new Error('Invalid credentials');
            err.status = 401;
            throw err;
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            const err = new Error('Invalid credentials');
            err.status = 401;
            throw err;
        }

        const token = jwt.sign({ userId: user._id }, JWT_SECRET, {
            expiresIn: JWT_EXPIRES_IN,
        });

        const userObj = user.toObject();
        delete userObj.password;

        res.status(200).json({
            success: true,
            message: 'Logged in successfully',
            data: { token, user: userObj },
        });
    } catch (error) {
        next(error);
    }
};

export const logOut = async (req, res, next) => {
    try {
        res.status(200).json({ success: true, message: 'Logged out successfully' });
    } catch (error) {
        next(error);
    }
};