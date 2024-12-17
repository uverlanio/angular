global class SaneamentoSchedule implements Schedulable {
    global void execute(SchedulableContext context) {
        // Executa o Batch Apex com lotes de 200 registros
        Database.executeBatch(new SaneamentoBatchable(), 200);
    }
}