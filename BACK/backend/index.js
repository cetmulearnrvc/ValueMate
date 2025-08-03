import app from "./app.js"
import dotenv from "dotenv"
import { connectDB } from "./db.js";
import pvr1_router from "./router/pvr1router.js";

import pvr3_router from "./router/pvr3router.js";
import federal_router from "./router/federalrouter.js";
import idbi_router from "./router/idbi_router.js";
import flat_router from "./router/sib_flat_router.js";
import land_router from "./router/sib_land_router.js";
import vacantland_router from "./router/sib_vacantland_router.js";
import canara_router from "./router/canara_router.js";
import nearby_router from "./router/nearbyRouter.js";
import sbi_flat_router from "./router/sbi_flat_router.js";
import sbi_land_router from "./router/sbi_land_router.js";

dotenv.config();

app.get('/',(req,res)=>{
    res.send("Hello world")
})

app.use('/api/v1',pvr1_router)
app.use('/api/v1',flat_router)
app.use('/api/v1',nearby_router)
app.use('/api/v1',pvr3_router);
app.use('/api/v1',idbi_router);
app.use('/api/v1',federal_router)
app.use('/api/v1',land_router)
app.use('/api/v1',vacantland_router);
app.use('/api/v1',canara_router);
app.use('/api/v1',sbi_flat_router);
app.use('/api/v1',sbi_land_router);


app.listen(3000,()=>
{
    console.log("server started at localhost 3000")
    connectDB()
})
