const connect = require("../db/connect");

module.exports = class eventoController {
  // criação de um evento
  static async createEvento(req, res) {
    const { nome, descricao, data_hora, local, fk_id_organizador } = req.body;

    if (!nome || !descricao || !data_hora || !local || !fk_id_organizador) {
      return res
        .status(400)
        .json({ error: "Todos os campos devem ser preenchidos" });
    }
    const query = ` INSERT INTO evento (nome,descricao,data_hora,local,fk_id_organizador) VALUES (?,?,?,?,?)`;
    const values = [nome, descricao, data_hora, local, fk_id_organizador];
    try {
      connect.query(query, values, (err) => {
        if (err) {
          console.log(err);
          return res.status(500).json({ error: "Erro ao criar evento!" });
        }
        return res.status(201).json({ message: "Evento criado com sucesso!" });
      });
    } catch (error) {
      console.log("Erro ao executar consulta: ", error);
      return res.status(500).json({ error: "Erro interno do servido" });
    }
  } // fim do 'createEvento'

  static async getAllEventos(req, res) {
    const query = `SELECT * FROM evento`;
    try {
      connect.query(query, (err, results) => {
        if (err) {
          console.log(err);
          return res.status(500).json({ error: "Erro ao buscar eventos" });
        }
        return res
          .status(200)
          .json({ message: "Eventos listados com sucesso", eventos: results });
      });
    } catch (error) {
      console.log("Erro ao executar a querry: ", error);
      return res.status(500).json({ error: "Erro interno do Servidor" });
    }
  } // fim do 'getAllEventos'

  static async updateEvento(req, res) {
    const { id_evento, nome, descricao, data_hora, local, fk_id_organizador } =
      req.body;

    if (
      !id_evento ||
      !nome ||
      !descricao ||
      !data_hora ||
      !local ||
      !fk_id_organizador
    ) {
      return res
        .status(400)
        .json({ error: "Todos os campos devem ser preenchidos" });
    }
    const query = ` UPDATE evento SET nome = ?,descricao = ?,data_hora = ?,local = ?, fk_id_organizador = ? WHERE id_evento = ?`;
    const values = [
      nome,
      descricao,
      data_hora,
      local,
      fk_id_organizador,
      id_evento,
    ];
    try {
      connect.query(query, values, (err, results) => {
        console.log("Resultados: ", results);
        if (err) {
          console.log(err);
          return res.status(500).json({ error: "Erro ao criar evento!" });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ message: "Evento não encontrado" });
        }
        return res
          .status(201)
          .json({ message: "Evento atualizado com sucesso: " });
      });
    } catch (error) {
      console.log("Erro ao executar consulta: ", error);
      return res.status(500).json({ error: "Erro interno do servidor" });
    }
  } // fim do 'updateEvento'

  static async deleteEvento(req, res) {
    const eventoId = req.params.id_evento;
    const query = `DELETE FROM evento WHERE id_evento = ?`;
    const values = [eventoId];
    try {
      connect.query(query, values, function (err, results) {
        if (err) {
          console.error(err);
          return res.status(500).json({ error: "Erro Interno do Servidor" });
        }
        if (results.affectedRows === 0) {
          return res.status(404).json({ error: "Evento não Encontrado" });
        }
        return res.status(200).json({ message: "Evento Excluido com Sucesso" });
      });
    } catch (error) {
      console.error(error);
      return res.status(500).json({ error: "Erro Interno do Servidor" });
    }
  }

  static async getEventosPorData(req, res) {
    const query = `SELECT * FROM evento`
    try {
      connect.query(query, (err, results) => {
        if (err) {
          console.error(err);
          return res.status(500).json({ error: "Erro ao buscar eventos" });
        }
        const dataEvento = new Date(results[0].data_hora);
        const dia = dataEvento.getDate()
        const mes = dataEvento.getMonth()+1
        const ano = dataEvento.getFullYear()
        console.log(dia+'/'+mes+'/'+ano);
        
        const now = new Date()
        const eventosPassados = results.filter(evento => new Date(evento.data_hora)<now);
        const eventosFuturos = results.filter(evento => new Date(evento.data_hora)>=now);

        const diferencaMs = eventosFuturos[0].data_hora.getTime() - now.getTime();
        const dias = Math.floor(diferencaMs/(1000*60*60*24));
        const horas = Math.floor(diferencaMs%(1000*60*60*24)/(1000*60*60))
        console.log(diferencaMs,'Falta:', dias, 'dias', horas,'horas')

        //comparacao datas
        const dataFiltro = new Date('2024-12-15').toISOString().split("T");
        const eventosDia = results.filter(evento => 
          new Date(evento.data_hora).toISOString().split("T")[0] === dataFiltro[0]
        );
        console.log("Eventos: ", eventosDia);

        console.log("Data Filtro: ", dataFiltro);


        return res.status(200).json({message: "Ok", eventosPassados, eventosFuturos});
      });
    } catch (error) {
      console.error(erro);
      return res.status(500).json({ error: "Erro ao buscar eventos" });
    }
  };

  static async getEventosPorData7Dias(req, res) {
    const dataFiltro = new Date(req.params.data).toISOString().split("T");
    const dataLimite = new Date(req.params.data);  // Converte a data recebida em um objeto Date
    dataLimite.setDate(dataLimite.getDate() + 7);  // Adiciona os dias
    console.log("Data Fornecida:", dataFiltro, "\n");
    console.log("Data Limite:", dataLimite, "\n");
    const query = `SELECT * FROM evento`;
    try {
      connect.query(query, (err, results) => {
        if (err) {
          console.log(err);
          return res.status(500).json({ error: "Erro ao buscar eventos" });
        }
        const eventosSelecionados = results.filter(
          (evento) =>
            new Date(evento.data_hora).toISOString().split("T")[0] >= dataFiltro[0] && new Date(evento.data_hora).toISOString().split("T")[0] < dataLimite.toISOString().split("T")[0]
        );
        console.log(eventosSelecionados);
        return res
          .status(200)
          .json({ message: "Eventos: ", eventosSelecionados });
      });
    } catch (error) {
      console.log("Erro ao executar a querry: ", error);
      return res.status(500).json({ error: "Erro interno do Servidor" });
    }
  } // fim do 'getEventosPorData7Dias'

};
