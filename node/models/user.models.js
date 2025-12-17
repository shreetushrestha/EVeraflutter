import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
    name: {
        type: String,
        required: [true, 'User Name is required'],
        trim: true,
        minLength: 3,
        maxLength: 30,
    },

    email: {
        type: String,
        required: [true, 'User Email is required'],
        unique: true,
        trim: true,
        lowercase: true,
        match: [/\S+@\S+\.\S+/, 'Please fill a valid email address'],
    },

    phone: {
        type: String,
        required: [true, "Phone number is required"],
        match: [/^\d{10}$/, "Phone number must be exactly 10 digits"],
    },

    password: {
        type: String,
        required: [true, 'User Password is required'],
        minLength: 6,
    },

}, { timestamps: true });

const User = mongoose.model('User', userSchema);
export default User;
