import User from '../models/user.models.js';

export const getUsers = async(req, res, next) =>{
    try{
        const users = await User.find();

        res.status(200).json({success: true, data: users});
    }catch(error){
        next(error);
    }
}

export const getUser = async(req, res, next) =>{
    try{
        const user = await User.findById(req.params.id).select('-password');

        if(!user){
            const error = new Error('User not found');
            error.statusCode = 404;
            throw error;
        }

        res.status(200).json({success: true, data: user});
    }catch(error){
        next(error);
    }
}

/**
 * UPDATE USER PROFILE
 */
export const updateUser = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const { name, email, phone } = req.body;

    if (!name && !email && !phone) {
      return res.status(400).json({ message: "At least one field must be provided" });
    }

    // Validate phone if provided
    if (phone && !/^\d{10}$/.test(phone)) {
      return res.status(400).json({ message: "Phone number must be exactly 10 digits" });
    }

    // Find the user
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: "User not found" });

    // Update only provided fields
    if (name) user.name = name;
    if (email) user.email = email;
    if (phone) user.phone = phone;

    await user.save();

    res.status(200).json({
      success: true,
      message: "User updated successfully",
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role
      },
    });
  } catch (error) {
    next(error);
  }
};