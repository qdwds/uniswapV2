
import { expect } from "chai";
import { id } from "./deploy/deploy";
describe("TransferHelper", ()=>{

    it("0x095ea7b3",async () => {
        // console.log(id("approve(address,uint256)"));
        
        expect(id("approve(address,uint256)").slice(0, 10)).to.eq("0x095ea7b3")
    })
})