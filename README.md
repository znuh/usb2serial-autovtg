# USB2serial-AutoVtg
<img src="https://user-images.githubusercontent.com/198567/280999817-36e1963b-0e59-43e5-ac5e-20795e093492.jpg" width="640"><br>
USB to serial adapter with automatic target voltage detection, buffered IOs, 1.8V to 5V support and backflow current protection

## Why yet another USB to serial adapter?
This adapter adds several **convenience & protection features** most existing adapters do not have.

I'll use an analogy to explain this: For voltage measurements you can either use a naked analog-to-digital converter (ADC) or a digital multimeter/oscilloscope.
Digital multimeters/oscilloscopes have analog frontends to support different voltage ranges and take a bit of abuse (i.e. overvoltage, etc.) with no permanent damage, while an ADC by itself does not have these features.

When it comes to USB to serial converters the situation is similar. The converter chip by itself usually doesn't support multiple voltage ranges and can be damaged by overvoltage and overcurrent.  
However, an even bigger problem is that adapters can also damage the target system when set to the wrong voltage, or through **backflow current** when connected to an unpowered target. (See [below](#backflow_current) for a detailed explanation.)  
To address these issues, this adapter uses **[buffered IOs](#backflow_current)** with backflow current protection and **[automatic target voltage detection](autovtg)**.

## Adapter Specifications
<table class="table table-striped">
  <tbody class="table-group-divider">
    <tr>
      <td class="td1">IC:</td>
      <td><a href="https://ftdichip.com/products/ft234xd/">FTDI FT234XD</a></td>
    </tr>
    <tr>
      <td class="td1">Signals:</td>
      <td>GND, Rx, Tx, (Vtg - optional Vtarget reference voltage input)</td>
    </tr>
    <tr>
      <td class="td1">IO Voltage:</td>
      <td>1.8V - 5V (automatic detection or via reference pin)</td>
    </tr>
    <tr>
      <td class="td1">Baudrates:</td>
      <td>
		  <ul>
		  <li>4800 Baud - 250kBaud with <a href="#autovtg" class="link-primary">automatic target voltage detection</a></li>
		  <li>300 Baud - 3MBaud with target voltage provided through Vtg pin</li>
		  </ul>
      </td>
    </tr>
    <tr>
      <td class="td1">Buffered IOs:</td>
      <td><a href="https://assets.nexperia.com/documents/data-sheet/74LVC1G17.pdf">74LVC1G17</a> Buffers<br>
      These buffers prevent <a href="#backflow_current" class="link-primary">potentially damaging backflow current</a> when only the target <b>or</b> the USB to Serial Adapter is powered.
      </td>
    </tr>
    <tr>
      <td class="td1">IO Protection:</td>
      <td>120Ω series resistors on Rx/Tx.<br>
      These resistors protect both the USB to Serial Adapter and the target by limiting the short-circuit current 
      when the adapter is connected to the target incorrectly (e.g. adapter Tx connected to target Tx).<br>
      Current limits:
      <ul>
      <li>@1.8V: &lt;15mA</li>
      <li>@3.3V: &lt;28mA</li>
      <li>@5V: &lt;42mA</li>
      </ul>
      </td>
    </tr>
    <tr>
      <td class="td1">Connector:</td>
      <td>USB-C</td>
    </tr>
    <tr>
      <td class="td1">LED:</td>
      <td>Rx/Tx (single LED for both)</td>
    </tr>
</tbody>
</table>

<a id="backflow_current"></a>
## What is backflow current protection?
The most common USB to Serial Adapters have unbuffered IOs. This means the in- and outputs of the converter IC are
directly connected to the target. When such an adapter is not connected to USB, but to a powered target, current flows
from the output of the target into the input of the converter IC and to Vdd through the 
<a href="https://electronics.stackexchange.com/questions/179450/power-and-ground-clamp-diodes-in-cmos-io-buffer">
clamping diode</a>.  
  
![backflow](https://github.com/znuh/usb2serial-autovtg/assets/198567/0968fbaf-4c8f-41ee-8fd6-8c0b365975ac)  
  
The same problem occurs when the USB to Serial Adapter is connected to USB and an unpowered target. Current from the
converter output flows into the target input and to Vdd of the target through the input clamping diode.
This penomenon is called
<a href="https://e2e.ti.com/blogs_/b/analogwire/posts/back-powering-why-are-the-lights-on-when-the-power-is-off">
back powering</a>.

Backflow current often exceeds the maximum ratings of the ICs involved. This can permanently damage both the 
(expensive) target and the USB to Serial Adapter. Modern 1.8V devices are more prone to permanent damage through
backflow current because their IOs are significantly less robust than old 5V IOs.<br>
Suitable IO buffers (such as the <a href="https://assets.nexperia.com/documents/data-sheet/74LVC1G17.pdf">74LVC1G17</a>)
prevent this by limiting the backflow current to a few µA.
With these buffers having an unpowered adapter connected to a powered board - and vice versa - no longer poses a risk.

<a id="autovtg"></a>
## How does the automatic target voltage detection work?
Connecting a 3.3V USB to Serial Adapter to a 1.8V target (or a 5V adapter to a 3.3V target) can permanently damage
the target, because the excessive voltage can result in a high current through the clamping diode and an overvoltage
on the Vdd supply of the target.

Therefore buffered USB to Serial Adapters usually have a Vtarget (or Vtg/Vref) sense input for the target IO voltage.
The sense input is used to match the IO voltage of the adapter to the target.
This adapter also has such a Vtarget sense input, but in most cases connecting it is optional, because the adapter
can <b>detect the target IO voltage automatically</b> by deriving it from the target Tx signal.

![autovtg2](https://github.com/znuh/usb2serial-autovtg/assets/198567/48606e8c-6bbc-486a-ab4a-0f37fbcbb975)

This is done with a <a href="https://www.analog.com/en/technical-articles/ltc6244-high-speed-peak-detector.html">
peak detector circuit</a> based on a common Operational Amplifier (a <a href="https://www.ti.com/product/LMV358A">LMV358A</a>). The automatic detection is designed to work with baud rates ranging from 4800 Baud up to 250kBaud.
For slower or higher baudrates (and for unidirectional use-cases where the target does not have a Tx signal) 
a regular Vtarget sense pin is also available.

# License
Designed by Benedikt Heinz &lt;hunz at mailbox.org&gt;

Creative Commons Attribution/Share-Alike, all text above must be included in any redistribution. See license.txt for additional details.
