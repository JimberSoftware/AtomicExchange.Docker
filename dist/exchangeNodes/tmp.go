
func printContractInfo(hastings types.Currency, condition types.AtomicSwapCondition, secret types.AtomicSwapSecret) {
	var amountStr string
	if !hastings.Equals(types.Currency{}) {
		amountStr = fmt.Sprintf(`
Contract value: %s`, _CurrencyConvertor.ToCoinStringWithUnit(hastings))
	}

	var secretStr string
	if secret != (types.AtomicSwapSecret{}) {
		secretStr = fmt.Sprintf(`
Secret: %s`, secret)
	}

	cuh := condition.UnlockHash()

	fmt.Printf(`Contract address: %s%s
Receiver's address: %s
Sender's (contract creator) address: %s

SecretHash: %s%s

TimeLock: %[7]d (%[7]s)
TimeLock reached in: %s
`, cuh, amountStr, condition.Receiver, condition.Sender, condition.HashedSecret,
		secretStr, condition.TimeLock,
		time.Unix(int64(condition.TimeLock), 0).Sub(time.Now()))
}