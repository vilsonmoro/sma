!start.

/*preco(participant1, 100).
preco(participant2, 80).
preco(participant3, 120).
preco(participant4, 70).
preco(participant5, 90).*/

+!start
    <- .my_name(Me);
       .print("Eu sou o participant.");
       .wait(1000);
       .df_search("initiator",Initiators);
       .print("Initiators encontrados: ", Initiators);
       !registrar_em_initiators(Initiators, Me).
     
+!registrar_em_initiators([], Me)
    <- .print(Me, " terminou o registro nos initiators.").

+!registrar_em_initiators([I|Resto], Me)
    <- .print(Me, " registrando em ", I);
       .send(I, tell, registrar(Me));
       !registrar_em_initiators(Resto, Me).
       
+cfp(Servico)[source(Sender)]
    <- .print("Recebi um CFP de ", Sender);
       .print("Servico solicitado: ", Servico);
       .my_name(Me);
       !fazer_proposta(Me, Sender, Servico).

+!fazer_proposta(Me, Sender, Servico)
    <- .random(R);
       Preco = math.floor(50 + R * 100);
       .print("Minha proposta para ", Servico, " e ", Preco);
       .send(Sender, tell, proposta(Servico, Preco)).

+accept(Servico)[source(Sender)]
    <- .print("Minha proposta para ", Servico, " foi ACEITA por ", Sender);
       .print("Executando o serviço: ", Servico);
       .send(Sender, tell, concluido(Servico)).

+reject(Servico)[source(Sender)]
    <- .print("Minha proposta para ", Servico, " foi REJEITADA por ", Sender).

