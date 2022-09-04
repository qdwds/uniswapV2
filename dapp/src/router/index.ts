import { createRouter, createWebHashHistory, RouteRecordRaw } from 'vue-router'
const routes: Array<RouteRecordRaw> = [
    {
        path:"/",
        name:"Layout",
        redirect:"/liquidity",
        component: () => import("@/layouts/index.vue"),
        children:[
            {
                path:"/liquidity",
                name:"Liquidity",
                component: () => import("@/views/liquidity/index.vue")
            },
            {
                path:"/removeLiquidity",
                name:"RemoveLiquidity",
                component: () => import("@/views/removeLiquidity/index.vue")
            },
            {
                path:"/swap",
                name:"Swap",
                component: () => import("@/views/swap/index.vue")
            },
            {
                path:"/t",
                name:"T",
                component: () => import("@/views/test.vue")
            }
        ]
    },
    
]

const router = createRouter({
    history: createWebHashHistory(),
    routes
})

export default router