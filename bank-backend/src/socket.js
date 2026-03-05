let io = null;

function initIO(server) {
  const socketIO = require("socket.io");

  io = socketIO(server, {
    cors: {
      origin: "*",
    },
  });

  io.on("connection", (socket) => {
    console.log("🔌 Client connected:", socket.id);

    socket.on("join", (accountNo) => {
      socket.join(accountNo);
      console.log("👤 User joined room:", accountNo);
    });

    socket.on("disconnect", () => {
      console.log("❌ Client disconnected:", socket.id);
    });
  });
}

function getIO() {
  if (!io) {
    throw new Error("Socket.io not initialized");
  }
  return io;
}

module.exports = { initIO, getIO };
