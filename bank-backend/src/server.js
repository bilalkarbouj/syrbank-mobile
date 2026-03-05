const http = require("http");
const app = require("./app");
const { initIO } = require("./socket");



const server = http.createServer(app);


initIO(server);


const PORT = process.env.PORT || 3000;
server.listen(PORT, "0.0.0.0",() => {
  console.log("🚀 Server running on", PORT);
});





