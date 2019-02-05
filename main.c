/* Driverlib includes (HAL) */
#include "driverlib.h"

/* FreeRTOS includes */
#include "FreeRTOS.h"
#include "task.h"

/* Function prototypes */
void vBlinkRedLEDTask( void* pvParameters );
void vBlinkGreenLEDTask( void* pvParameters );
static void prvSetupHardware( void );

int main( void )
{
    prvSetupHardware();

    /* Two simple tasks */
    xTaskCreate(
        vBlinkRedLEDTask, "BlinkyR", configMINIMAL_STACK_SIZE, NULL, tskIDLE_PRIORITY, NULL );
    xTaskCreate(
        vBlinkGreenLEDTask, "BlinkyG", configMINIMAL_STACK_SIZE, NULL, tskIDLE_PRIORITY, NULL );

    vTaskStartScheduler();

    for ( ;; )
        ;

    return 0;
}

/* Do any necessary hardware initialization */
static void prvSetupHardware( void )
{
    // Stop WDT
    WDT_A_hold( WDT_A_BASE );
}

/* Simple blinker task. Blinks on-board Red LED every 0.6s */
void vBlinkRedLEDTask( void* pvParameters )
{
    // P1.0 as output
    GPIO_setAsOutputPin( GPIO_PORT_P1, GPIO_PIN0 );

    for ( ;; )
    {
        GPIO_toggleOutputOnPin( GPIO_PORT_P1, GPIO_PIN0 );
        vTaskDelay( (TickType_t)pdMS_TO_TICKS( 300 ) );
    }
}

/* Simple blinker task. Blinks on-board Green LED every 0.2s */
void vBlinkGreenLEDTask( void* pvParameters )
{
    // P4.7 as output
    GPIO_setAsOutputPin( GPIO_PORT_P4, GPIO_PIN7 );

    for ( ;; )
    {
        GPIO_toggleOutputOnPin( GPIO_PORT_P4, GPIO_PIN7 );
        vTaskDelay( (TickType_t)pdMS_TO_TICKS( 100 ) );
    }
}
