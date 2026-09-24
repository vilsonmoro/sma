!start.

+!start
    : servico(Servico) & estrategia(Estrategia)
    <- .my_name(Me);
       .print("Eu sou o ", Me);
       .print("Ofereço: ", Servico, "com estrategia: ", Estrategia);
       .wait(1000);
       .df_search("initiator",Initiators);
       .print("Initiators encontrados: ", Initiators);
       !registrar_em_initiators(Initiators, Me, Servico).
     
+!registrar_em_initiators([], Me, Servico)
    <- .print(Me, " terminou o registro nos initiators.").

+!registrar_em_initiators([I|Resto], Me, Servico)
    <- .print(Me, " registrando em ", I, " para o serviço: ", Servico);
       .send(I, tell, registrar(Me, Servico));
       !registrar_em_initiators(Resto, Me, Servico).
       
+cfp(CnpId,Servico)[source(Sender)]
    <- .print("Recebi ", CnpId, " de ", Sender);
       .print("Servico solicitado: ", Servico);
       .my_name(Me);
       !fazer_proposta(CnpId, Me, Sender, Servico).

+!fazer_proposta(CnpId, Me, Sender, Servico)
    : estrategia(Estrategia)
    <- .random(R);
       !calcular_preco(Estrategia, R, Preco);
       .print(CnpId,": ", Me, " estrategia: ", Estrategia, "proposta=",Preco);
       .send(Sender, tell, proposta(CnpId, Servico, Preco)).

+!calcular_preco(economica, R, Preco)
    <- Preco = math.floor(50 + R * 30).

+!calcular_preco(normal, R, Preco)
    <- Preco = math.floor(70 + R * 50).

+!calcular_preco(premium, R, Preco)
    <- Preco = math.floor(100 + R * 50).

+accept(CnpId,Servico)[source(Sender)]
    <- .print(CnpId,": minha proposta para ", Servico, " foi ACEITA por ", Sender);
       .print(CnpId,": executando o serviço: ", Servico);
       .send(Sender, tell, concluido(CnpId,Servico)).

+reject(CnpId, Servico)[source(Sender)]
    <- .print(CnpId,": minha proposta para ", Servico, " foi REJEITADA por ", Sender).

