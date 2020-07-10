/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "gpio.h"

#include "FreeRTOS.h"
#include "task.h"
/* Private function prototypes -----------------------------------------------*/
static void SystemClock_Config(void);

static void prvSetupTask(void* parameter);

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{
  SystemCoreClockUpdate();

  HAL_Init();

  SystemClock_Config();

  xTaskCreate( prvSetupTask,         /* The function that implements the task. */
          "Setup",                             /* The text name assigned to the task - for debug only as it is not used by the kernel. */
          configMINIMAL_STACK_SIZE,         /* The size of the stack to allocate to the task. */
          NULL,                             /* The parameter passed to the task - not used in this case. */
          255,  /* The priority assigned to the task. */
          NULL );                           /* The task handle is not required, so NULL is passed. */
  vTaskStartScheduler();
  while (1)
  {
  }
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
static void SystemClock_Config(void)
{

}

/**
  * @brief Setup Task
  * @retval None
  */
static void prvSetupTask(void* parameter)
{
    BSP_GPIO_Init();
    while (1)
    {
      LL_GPIO_ResetOutputPin(GPIOA, LL_GPIO_PIN_0);
      vTaskDelay(200);
      LL_GPIO_SetOutputPin(GPIOA, LL_GPIO_PIN_0);
      vTaskDelay(800);
    }
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{ 
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     tex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
