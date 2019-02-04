/* Driverlib includes (HAL) */
#include "driverlib.h"

/* FreeRTOS includes */
#include "FreeRTOS.h"
#include "task.h"

/* Function prototypes */
void vBlinkLEDTask( void* pvParameters );
static void prvSetupHardware( void );

int main( void )
{
    prvSetupHardware();

    xTaskCreate(
        vBlinkLEDTask, "Blinky", configMINIMAL_STACK_SIZE, NULL, tskIDLE_PRIORITY, NULL );

    vTaskStartScheduler();

    for ( ;; )
        ;

    return 0;
}

/* Do any necessary hardware initialization */
static void prvSetupHardware( void )
{
    taskDISABLE_INTERRUPTS();
    // Stop WDT
    WDT_A_hold( WDT_A_BASE );
}

/* Simple blinker task. Blinks on-board LED every 0.5s */
void vBlinkLEDTask( void* pvParameters )
{
    // P1.0 as output
    GPIO_setAsOutputPin( GPIO_PORT_P1, GPIO_PIN0 );

    for ( ;; )
    {
        GPIO_toggleOutputOnPin( GPIO_PORT_P1, GPIO_PIN0 );
        vTaskDelay( (TickType_t)pdMS_TO_TICKS( 500 ) );
    }
}
