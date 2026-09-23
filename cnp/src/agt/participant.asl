!start.

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
       
+cfp(CnpId,Servico)[source(Sender)]
    <- .print("Recebi ", CnpId, " de ", Sender);
       .print("Servico solicitado: ", Servico);
       .my_name(Me);
       !fazer_proposta(CnpId, Me, Sender, Servico).

+!fazer_proposta(CnpId, Me, Sender, Servico)
    <- .random(R);
       Preco = math.floor(50 + R * 100);
       .print(CnpId,": Minha proposta para ", Servico, " e ", Preco);
       .send(Sender, tell, proposta(CnpId, Servico, Preco)).

+accept(CnpId,Servico)[source(Sender)]
    <- .print(CnpId,": minha proposta para ", Servico, " foi ACEITA por ", Sender);
       .print(CnpId,": executando o serviço: ", Servico);
       .send(Sender, tell, concluido(CnpId,Servico)).

+reject(CnpId, Servico)[source(Sender)]
    <- .print(CnpId,": minha proposta para ", Servico, " foi REJEITADA por ", Sender).

