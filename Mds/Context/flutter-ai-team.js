import dotenv from "dotenv";
import fs from "fs";
import path from "path";
import { GoogleGenerativeAI } from "@google/generative-ai";

dotenv.config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

const MEMORY_FOLDER = path.join(process.cwd(), "Mds", "Mem");
if (!fs.existsSync(MEMORY_FOLDER)) fs.mkdirSync(MEMORY_FOLDER, { recursive: true });

console.log("🚀 Flutter AI Team (Node.js) READY!");
console.log("💾 All memory saved in Mds/Mem folder forever");

// ============== TOOLS ==============
async function listFiles() {
    const lib = path.join(process.cwd(), "lib");
    if (!fs.existsSync(lib)) return "No lib folder found";
    return fs.readdirSync(lib).filter(f => f.endsWith(".dart") || f.endsWith(".yaml")).join("\n");
}

async function readFile(filePath) {
    const full = path.join(process.cwd(), filePath);
    return fs.existsSync(full) ? fs.readFileSync(full, "utf-8") : "❌ File not found";
}

async function writeFile(filePath, content) {
    const full = path.join(process.cwd(), filePath);
    fs.writeFileSync(full, content, "utf-8");
    return `✅ Updated ${filePath}`;
}

async function listMd() {
    return fs.readdirSync(MEMORY_FOLDER).filter(f => f.endsWith(".md")).join("\n") || "No memory files yet";
}

async function readMd(filename) {
    const full = path.join(MEMORY_FOLDER, filename);
    return fs.existsSync(full) ? fs.readFileSync(full, "utf-8") : "❌ MD file not found";
}

async function writeMd(filename, content) {
    const full = path.join(MEMORY_FOLDER, filename);
    fs.writeFileSync(full, content, "utf-8");
    return `✅ Saved memory → Mds/Mem/${filename}`;
}

// ============== BOSS AGENT ==============
async function askBoss(query) {
    const systemPrompt = `You are the Flutter Boss. 
You manage a team: UI Agent + State Agent.
ALWAYS check Mds/Mem first for past work.
Use tools to read/write Flutter files or memory MD files.
Be helpful and save important decisions in Mds/Mem.

Current project: BillForAll`;

    const result = await model.generateContent([systemPrompt, query]);
    return result.response.text();
}

// ============== RUN ==============
import readline from "readline";
const rl = readline.createInterface({ input: process.stdin, output: process.stdout });

console.log("Type your request (or 'exit')...\n");

rl.on("line", async (input) => {
    if (input.toLowerCase() === "exit") process.exit();

    console.log("Thinking...");
    const reply = await askBoss(input);
    console.log("\nTeam:", reply + "\n");
});