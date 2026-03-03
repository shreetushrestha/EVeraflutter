import express from "express";
import authorize from "../middlewares/auth.middleware.js";
import {
  addFavorite,
  removeFavorite,
  getFavorites
} from "../controllers/favorite.controller.js";

const favoritesRouter = express.Router();

favoritesRouter.post("/:stationId", authorize, addFavorite);
favoritesRouter.delete("/:stationId", authorize, removeFavorite);
favoritesRouter.get("/", authorize, getFavorites);

export default favoritesRouter;

