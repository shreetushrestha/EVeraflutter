import {Router} from 'express';
import authorize from '../middlewares/auth.middleware.js';
import Station from '../models/station.model.js';
import { createStation, deleteStation, getAllStations, getStationById, updateStation, getMyStations, toggleOperational } from '../controllers/station.controller.js';
import { authorizeRoles } from '../middlewares/role.middleware.js';

const stationRouter = Router();

stationRouter.get('/', getAllStations);

stationRouter.post('/', authorize, authorizeRoles('manager'), createStation);

stationRouter.get("/my-stations", authorize, getMyStations);

stationRouter.get('/:id',getStationById);

stationRouter.put("/:id", updateStation);

stationRouter.delete("/:id", deleteStation);

stationRouter.patch("/toggle-operational", authorize, toggleOperational);

export default stationRouter;