import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }

app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))


struct PokemonCard: Content {
    let name: String
    let imageUrl: String
}

let pokemons = [
    PokemonCard(name: "Pikachu Vangoh", imageUrl: "/images/image_ca9785.png"),
    PokemonCard(name: "Mega Charizard", imageUrl: "/images/image_ca9a88.png"),
    PokemonCard(name: "Team Rocket's Mewtwo", imageUrl: "/images/image_ca9e4a.png"),
    PokemonCard(name: "Mario Pikachu", imageUrl: "/images/image_ca9f00.png"),
    PokemonCard(name: "Skull Grunt Pikachu", imageUrl: "/images/image_caa24c.png"),
    PokemonCard(name: "Pikachu AR", imageUrl: "/images/image_caa2a1.png")
]


app.get { req -> Response in
    let html = """
    <!DOCTYPE html>
    <html lang="th">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>เปิดการ์ดโปเกม่อน V2</title>
        <style>
            body { text-align: center; font-family: 'Arial', sans-serif; background-color: #1a1a2e; color: white; margin-top: 50px; }
            
            /* ซองการ์ด */
            #pack { 
                width: 250px; height: 350px; 
                background: linear-gradient(135deg, #dfda3d, #ff4b2b); 
                border-radius: 15px; margin: 0 auto; 
                display: flex; align-items: center; justify-content: center; flex-direction: column;
                font-size: 24px; font-weight: bold; cursor: pointer;
                box-shadow: 0 10px 20px rgba(0,0,0,0.5);
                transition: transform 0.3s;
                border: 4px solid #fff;
            }
            #pack:hover { transform: scale(1.05); }
            
            /* เอฟเฟคสั่น */
            .shake { animation: shake 0.5s infinite; }
            @keyframes shake {
                0% { transform: translate(1px, 1px) rotate(0deg); }
                10% { transform: translate(-1px, -2px) rotate(-1deg); }
                20% { transform: translate(-3px, 0px) rotate(1deg); }
                30% { transform: translate(3px, 2px) rotate(0deg); }
                40% { transform: translate(1px, -1px) rotate(1deg); }
                50% { transform: translate(-1px, 2px) rotate(-1deg); }
                60% { transform: translate(-3px, 1px) rotate(0deg); }
                70% { transform: translate(3px, 1px) rotate(-1deg); }
                80% { transform: translate(-1px, -1px) rotate(1deg); }
                90% { transform: translate(1px, 2px) rotate(0deg); }
                100% { transform: translate(1px, -2px) rotate(-1deg); }
            }

            /* เอฟเฟคฉีกซอง */
            .tear { animation: tear 0.6s forwards ease-in; }
            @keyframes tear {
                0% { transform: scale(1); opacity: 1; filter: blur(0px); }
                40% { transform: scale(1.2) rotate(5deg); opacity: 0.8; }
                100% { transform: scale(0) rotate(-15deg); opacity: 0; filter: blur(5px); }
            }

            /* การ์ดผลลัพธ์ */
            #card-result { display: none; margin-top: 20px; }
            .card-image { width: 320px; border-radius: 15px; box-shadow: 0 0 30px rgba(255, 215, 0, 0.7); animation: flipIn 1s cubic-bezier(0.175, 0.885, 0.32, 1.275); }
            @keyframes flipIn {
                from { transform: perspective(600px) rotateY(90deg) scale(0.5); opacity: 0; }
                to { transform: perspective(600px) rotateY(0deg) scale(1); opacity: 1; }
            }
            h2 { color: #ffd700; text-shadow: 2px 2px 4px #000; margin-bottom: 20px; }
            button { background-color: #ffd700; color: #000; border: none; padding: 12px 25px; border-radius: 8px; font-weight: bold; cursor: pointer; margin-top: 25px; transition: 0.2s; }
            button:hover { background-color: #ffaa00; transform: scale(1.1); }
        </style>
    </head>
    <body>
        <h1>🔥 สุ่มการ์ดโปเกม่อน 🔥</h1>
        
        <!-- ซองการ์ด -->
        <div id="pack" onclick="openPack()">
            <span style="font-size: 50px;">❓</span>
            <p>กดเพื่อฉีกซอง!</p>
        </div>
        
        <!-- การ์ดที่เปิดได้ -->
        <div id="card-result">
            <h2 id="pokemon-name"></h2>
            <img id="pokemon-img" class="card-image" src="" alt="Pokemon Card">
            <br>
            <button onclick="resetPack()">เปิดซองใหม่</button>
        </div>

        <script>
            async function openPack() {
                const pack = document.getElementById('pack');
                pack.classList.add('shake'); // เริ่มสั่นซอง
                pack.onclick = null; // ป้องกันกดรัวๆ
                
                // ดึงข้อมูลการ์ดจากหลังบ้าน
                const response = await fetch('/draw');
                const data = await response.json();
                
                // จำลองเวลาสั่นซอง 1.2 วินาที ก่อนฉีก
                setTimeout(() => {
                    pack.classList.remove('shake');
                    pack.classList.add('tear'); 
                    
                    // รอให้ซองฉีกเสร็จ (0.6 วินาที) แล้วโชว์การ์ด
                    setTimeout(() => {
                        pack.style.display = 'none';
                        document.getElementById('card-result').style.display = 'block';
                        document.getElementById('pokemon-name').innerText = data.name;
                        document.getElementById('pokemon-img').src = data.imageUrl;
                    }, 600);
                }, 1200);
            }

            function resetPack() {
                const pack = document.getElementById('pack');
                pack.style.display = 'flex';
                pack.classList.remove('tear');
                pack.onclick = openPack;
                document.getElementById('card-result').style.display = 'none';
            }
        </script>
    </body>
    </html>
    """
    return Response(status: .ok, headers: ["Content-Type": "text/html; charset=utf-8"], body: .init(string: html))
}


app.get("draw") { req -> PokemonCard in
    return pokemons.randomElement()!
}

try app.run()
