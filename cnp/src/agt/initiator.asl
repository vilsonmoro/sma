
contador_registros(0).
contador_propostas(0).

!start.

+!start
    <- .my_name(Me);
       .print("Eu sou o ", Me);
       .df_register("initiator");
       .print("Registrado no DF como initiator");
       .print("Aguardando registro dos participants.").
       
@receber_registro[atomic]
+registrar(Agente, Servico)[source(Sender)]
    : contador_registros(N) & total_participants(Total)
    <- +participant(Agente);
       +oferece(Agente, Servico);
       NovoN = N + 1;
       -contador_registros(N);
       +contador_registros(NovoN);
       .print("Participant registrado: ", Agente, " serviço: ", Servico );
       .print("Participants registrados: ", NovoN, " de ", Total  );
       !verificar_registros(NovoN,Total).

+!verificar_registros(Quantidade, Total)
    : Quantidade < Total
    <- true.

+!verificar_registros(Quantidade, Total)
    : Quantidade == Total & total_cnps(I)
    <- .print("Todos os participants foram registrados.");
       .print("Quantidade de CNPs que serão executadas: ",I);
       !criar_cnps(1,I).
    
+!criar_cnps(Atual, Total)
    : Atual > Total
    <- .print("Todos os ", Total, " CNPs foram iniciados.").

+!iniciar_cnp(CnpId, Numero)
    : Numero mod 2 == 1
    <- !!enviar_cfp(CnpId, transporte).


+!iniciar_cnp(CnpId, Numero)
    : Numero mod 2 == 0
    <- !!enviar_cfp(CnpId, limpeza).

+!criar_cnps(Atual, Total)
    : Atual <= Total
    <- CnpId = cnp(Atual);
       +contador_propostas(CnpId, 0);
       .print("Criando ", CnpId);
       !iniciar_cnp(CnpId, Atual);
       Proximo = Atual + 1;
       !criar_cnps(Proximo, Total).


+!enviar_cfp(CnpId, Servico)
    <- .findall(P, oferece(P, Servico), Participants);
       .print("Iniciando ", CnpId, " para ", Servico);
       .print("Participants que ofercem ", Servico, " : ", Participants);
       !enviar_para_lista(CnpId,Participants, Servico).


+!enviar_para_lista(CnpId, [], Servico)
    <- .print(CnpId, ":CFPs enviados para todos os participants.").


+!enviar_para_lista(CnpId, [P|Resto], Servico)
    <- .print(CnpId, ":Enviando CFP para ", P);
       .send(P, tell,cfp(CnpId, Servico));
       !enviar_para_lista(CnpId, Resto,Servico).


// ======================================================
// RECEBIMENTO DAS PROPOSTAS
// ======================================================

@receber_proposta[atomic]
+proposta(CnpId,Servico, Preco)[source(Sender)]
    : contador_propostas(CnpId, N)
    <- .print(CnpId,": Recebi proposta de ",Sender," para ", Servico, " no valor de ", Preco );

       // Guarda a proposta
       +proposta_recebida(CnpId, Sender, Servico, Preco);

       // Incrementa o contador
       NovoN = N + 1;
       -contador_propostas(CnpId,N);
       +contador_propostas(CnpId,NovoN);
       .print(CnpId, ": proposta numero ", NovoN, " recebida.");
       !verificar_total(CnpId, Servico, NovoN).

+!verificar_total(CnpId, Servico, Quantidade)
    <- .findall(P, oferece(P, Servico), Participants);
       .length(Participants,TotalParticipants);
       !verificar_se_completo(CnpId, Servico, Quantidade, TotalParticipants ).


+!verificar_se_completo(CnpId, Servico, Recebidas, Esperadas)
    : Recebidas < Esperadas
    <- .print(CnpId,": propostas recebidas: ", Recebidas," de ", Esperadas ).

+!verificar_se_completo(CnpId, Servico, Recebidas,  Esperadas)
    : Recebidas == Esperadas
    <- .print(CnpId,": propostas recebidas: ", Recebidas, " de ", Esperadas);
       .print(CnpId, ": todas as propostas para ", Servico, " foram recebidas." );
       !selecionar_melhor(CnpId, Servico).


+!selecionar_melhor(CnpId, Servico)
    <- .findall([Preco,Agente], proposta_recebida(CnpId,Agente, Servico, Preco), Propostas);
       .print(CnpId,": propostas para selecao: ",Propostas);
       .sort(Propostas, Ordenadas);
       .print(CnpId,": propostas ordenadas: ",Ordenadas);
       !processar_melhor(CnpId, Servico, Ordenadas ).


// ======================================================
// PRIMEIRO ELEMENTO = MENOR PRECO
// ======================================================

+!processar_melhor(CnpId, Servico, [[Preco,Vencedor]|Restantes])
    <- .print(CnpId, ": melhor proposta encontrada.");
       .print(CnpId, ": Vencedor = ", Vencedor);
       .print(CnpId,": preco = ", Preco);
       .send(Vencedor, tell, accept(CnpId,Servico));
       !rejeitar_propostas(CnpId,Servico, Restantes).


+!rejeitar_propostas(CnpId, Servico, [])
    <- .print(CnpId,": todas as demais propostas foram rejeitadas.").


+!rejeitar_propostas(CnpId, Servico, [[Preco,Agente]|Restantes])
    <- .print(CnpId, ": Rejeitando proposta de ", Agente," no valor de ", Preco);
       .send(Agente, tell, reject(CnpId,Servico));
       !rejeitar_propostas(CnpId,Servico, Restantes).


+concluido(CnpId, Servico)[source(Sender)]
    <- .print(CnpId, ": O agente ",Sender, " concluiu o servico ",  Servico);
       .print(CnpId,": CNP finalizado com sucesso.").