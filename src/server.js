//Importa a instância do Express configurada em index.js
const app = require("./index");
const cors = require('cors');
//Configuraçao dos CORS com origens permitidas
const corsOptions = {
    origin: '*', //Subtitua pela origem permitida
    methods: 'GET, HEAD, PUT, PATCH, POST, DELETE',//metodos https permitidos 
    credentials: true, //Permite o uso de cookies e credenciais
    optionSucessStatus: 204, //define o status de resposta para o método OPTIONS
};

//aplicando o middleware CORS no app
app.use(cors(corsOptions));
//Inicia o servidor na porta 5000, tornando a API acessível em http://localhost:5000
app.listen(5000);