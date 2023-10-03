public class LockTask {
@InvocableMethod (label='Lock Tasks')
public Static void LockTasks(List<Id> taskIds){
    List<Task> listTasksLock= [Select Id from Task where id =:taskIds] ;
    for (Task tasksToLock : listTasksLock)

  {

      Approval.lock(tasksToLock.id);

  }
}
}