/**
 * Created by Alessandro Ponte on 16/07/2019.
 */
// PLV-2312 INICIO
trigger HerokuLogsTrigger on HerokuLogs__e (after insert) {
    new HerokuLogsTriggerHandler().run();
}
// PLV-2312 FIM